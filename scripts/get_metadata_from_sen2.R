library(rgee)

ee_Initialize()

# Get parameters from a image
s2id <- "20190212T142031_20190212T143214_T19FDF"
ee_get_parameters(s2id)

# From Google Earth Engine ID to Sentinel ID or viceversa
sen_id <- ees2id_to_s2productid(s2id)
s2productid_to_ees2id(sen_id)
