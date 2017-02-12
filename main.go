package main

import (
	_ "mpaths-web/routers"
	"os"
	"strconv"

	"github.com/astaxie/beego"
)

func main() {
	beego.BConfig.Listen.HTTPPort, _ = strconv.Atoi(os.Getenv("PORT"))
	beego.Run()
}
