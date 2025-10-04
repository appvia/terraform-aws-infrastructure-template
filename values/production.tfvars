# Name of the VPC provisioned within the landing zone
vpc_name = "lz-main"

tags = {
  Environment = "(Production|Development|Test|Sandbox)"
  Owner       = "(Solutions|Engineering|Support|Operations)"
  Product     = "(LandingZone|Identity|Compliance|Platform|Sandbox|MyProduct)"
  Repository  = "https://github.com/appvia/terraform-aws-infrastructure-template"
}
