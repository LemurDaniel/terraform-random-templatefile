app = {
  name        = "${appName}"
  environment = "${environment}"
  url         = "https://${appName}.${environment}.example.com"
}

database = {
  host            = "${appName}-db.${environment}.internal"
  port            = 5432
  max_connections = "${maxConnections}"
}

features = {
  debug = "${debug}"
}

tags = ["${appName}", "${environment}"]
