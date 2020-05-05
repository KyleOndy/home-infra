provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# todo: move away from amazon DNS
locals {
  kyleondy_com_zone_id = "ZKVOKK3QLMSZX"
  aidenody_com_zone_id = "Z152J166VXL7LK"
  ondy_org_zone_id     = "Z36NHNX8W4NGAX"
  ondt_xyz_zone_id     = "Z1S99KRA07Z1WD"
  ondy_me_zone_id      = "ZWXJ4RSGMEPKY"
}
