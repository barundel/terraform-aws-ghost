//resource "aws_route53_record" "ghost" {
//  count = var.create_route53_record ? 1 : 0
//
//  zone_id = data.aws_route53_zone.this[0].zone_id
//  name    = var.route53_record_name != null ? var.route53_record_name : var.name
//  type    = "A"
//
//  alias {
//    name                   = module.alb.this_lb_dns_name
//    zone_id                = module.alb.this_lb_zone_id
//    evaluate_target_health = true
//  }
//}