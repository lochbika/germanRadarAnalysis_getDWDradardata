library("dwdradar")
library("raster")
library("ncdf4")
library("doFuture")
library("iterators")

# define environment
in.path <- "download/"
out.path <- "processed_bin/"

months <- sprintf("%02d", seq(3,11))
years <- as.character(seq(2001, 2020))
days <- sprintf("%02d", seq(1, 31))
hours <- sprintf("%02d", seq(0, 23))
minutes <- sprintf("%02d", seq(0, 55, 5))

# define radklim grid
x.lowerleft <- c(-443.462)
y.lowerleft <- c(-4758.645)
nx <- 900
ny <- 1100
unit.coords <- "km"
x.coords <- seq(from = x.lowerleft,
                by = 1,
                length.out = nx)
y.coords <- seq(from = y.lowerleft,
                by = 1,
                length.out = ny)
nts <- 288

# Set up the environment for parallel processing
registerDoFuture()
plan(multisession)

out.n <- foreach(year = iter(years)) %dopar% {
  for (month in months) {
    for (day in days) {
      print("Processing:")
      # construct tar.gz archive file name and check if it exists
      tarfile <-
        paste(in.path, "YW2017.002_", year, month, day, ".tar.gz", sep = "")
      extract.dir <-
        paste(in.path, "YW2017.002_", year, month, day, "/", sep = "")
      print(tarfile)
      if (!file.exists(tarfile)) {
        print("File for day does not exist")
        next
      }
      # create a daily data set
      # open and define the nc file for writing
      out.fname <-
        paste(
          out.path,
          "/raa01-yw2017.002_10000-",
          substr(year, 3, 4),
          month,
          day,
          "-dwd---bin.nc",
          sep = ""
        )
      
      # define the time index for this particular day
      start <-
        as.POSIXct(paste(year, month, day, " 00:00", sep = ""),
                   format = "%Y%m%d %H:%M",
                   tz = "UTC")
      end <-
        as.POSIXct(paste(year, month, day, " 23:55", sep = ""),
                   format = "%Y%m%d %H:%M",
                   tz = "UTC")
      datetime <- as.numeric(seq(
        from = start,
        by = 300,
        to = end
      ))
      
      # Define some straightforward dimensions
      x <- ncdim_def("x", "km", x.coords)
      y <- ncdim_def("y", "km", y.coords)
      t <-
        ncdim_def(
          "time",
          "seconds since 1970-01-01",
          datetime,
          unlim = TRUE,
          calendar = "gregorian"
        )
      
      # variable
      new.var <-
        ncvar_def(
          "precipitation",
          units = "mm/5min",
          dim = list(x, y, t),
          missval = -9.0,
          prec = "float",
          compression = 6
        )
      nc.out <- nc_create(out.fname, new.var)
      
      # create temporary directory and extract data to it
      system(paste("mkdir -p", extract.dir))
      system(paste("tar xvf", tarfile, "-C", extract.dir))
      
      # create the array that will hold all matrixes for this day
      #data.day <- array(dim = c(nx, ny, nts))
      ts <- 1 # counter for time steps
      
      # start reading 5 minute binary files and save them as NetCDF
      for (hour in hours) {
        for (minute in minutes) {
          # read the binary file
          in.bin <-
            paste(
              extract.dir,
              "raa01-yw2017.002_10000-",
              substr(year, 3, 4),
              month,
              day,
              hour,
              minute,
              "-dwd---bin",
              sep = ""
            )
          data.bin <- readRadarFile(in.bin, clutter = 0.0)
          data.bin <- t(data.bin$dat)[, seq(ny, 1,-1)]
          # write the whole day into the netCDF file and close it
          ncvar_put(
            nc.out,
            "precipitation",
            data.bin,
            start = c(1, 1, ts),
            count = c(nx, ny, 1)
          )
          ts <- ts + 1
        }
      }
      
      #rm(data.day)
      nc_close(nc.out)
      # remove after operations
      system(paste("rm -rf", extract.dir))
    }
  }
}