library(rgee)

ee_Initialize()


download_point <- function(point_name, output = ".") {
  # Create folder
  point_dir <- sprintf("%s/%s", output, point_name)
  dir.create(point_dir, showWarnings = FALSE)
  
  # cloudsen12 level find the point
  files_points_general <- googledrive::drive_ls(
    path = as_id("1BeVp0i-dGSuBqCQgdGZVDj4qzX1ms7L6"),
    q = sprintf("name contains '%s'", point_name)
  )
  
  # POINT level 
  files_points <- googledrive::drive_ls(
    path = as_id(files_points_general$id)
  )
  folder_id <- files_points_general$id
  
  
  # List files (Get SENTINEL_2 ID)
  img_to_download <- files_points[grepl("^[0-9]", files_points$name),]
  img_drive_ids <- img_to_download$id
  
  
  for (index in 1:5) {
    drive_id <- img_to_download$id[index]
    
    # IMG level
    files_IMG <- googledrive::drive_ls(
      path = as_id(drive_id)
    )
    
    # INPUT LEVEL
    files_input <- googledrive::drive_ls(
      path = as_id(files_IMG[files_IMG$name == "input",]$id)
    )
    
    # Download only s2 Bands 
    to_download <- files_input[grepl("B[0-9]+\\.tif$|B8A.tif", files_input$name),]
    
    # Img Folder
    img_folder <- sprintf("%s/%s/", point_dir, img_to_download$name[index])
    dir.create(img_folder, showWarnings = FALSE)
    
    for (z in 1:13) {
      drive_download(
        file = to_download[z,],
        path = paste0(img_folder, to_download[z,]$name),
        overwrite = TRUE
      ) 
    }
  }
}


ee_get_parameters <- function(s2id) {
  ee_s2_img <- ee$Image(sprintf("COPERNICUS/S2/%s", s2id))
  geom <- ee_as_sf(ee_s2_img$geometry())
  xy_max <- apply(st_coordinates(geom$geometry), 2, max)[c("X", "Y")]
  azimuth_angle <- ee_s2_img$get("MEAN_SOLAR_AZIMUTH_ANGLE")$getInfo()
  zenith_angle <- ee_s2_img$get("MEAN_SOLAR_ZENITH_ANGLE")$getInfo()
  list(xy_max = xy_max, azimuth = azimuth_angle, zenith = zenith_angle)  
}

ees2id_to_s2productid <- function(id) {
  ee_s2_img <- ee$Image(sprintf("COPERNICUS/S2/%s", id))
  ee_s2_img$get("PRODUCT_ID")$getInfo()
}

s2productid_to_ees2id <-  function(id) {
  ee$ImageCollection("COPERNICUS/S2") %>% 
    ee$ImageCollection$filterMetadata('PRODUCT_ID', 'equals', id) %>% 
    ee$ImageCollection$first() %>% 
    ee$Image$get("system:id") %>% 
    ee$ComputedObject$getInfo()
}

# Download a point from Google Drive
point_name <- "point_0001"
download_point(point_name, output = ".")
