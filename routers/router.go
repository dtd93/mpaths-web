package routers

import (
	"mpaths-web/controllers"

	"github.com/astaxie/beego"
)

func init() {
	beego.Router("/", &controllers.MainController{})
	beego.Router("/dashboard", &controllers.DashboardController{})
	beego.Router("/add_point", &controllers.DashboardController{}, "get:AddPoint")
	beego.Router("/get_latest_modification", &controllers.DashboardController{}, "get:GetLatestModification")
}
