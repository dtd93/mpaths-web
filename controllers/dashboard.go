package controllers

import (
	"mpaths-web/models"

	"math/rand"
	"time"

	"github.com/astaxie/beego"
	"github.com/novikk/mpaths-alg/algorithm"
	malg "github.com/novikk/mpaths-alg/models"
)

type DashboardController struct {
	beego.Controller
}

func (c *DashboardController) Get() {
	//TODO
	radius := 200.0
	var data []models.Client
	la := 41.543664
	lo := 2.425390
	var cli models.Client
	for i := 0; i < 5; i++ {
		lo = lo + 0.00300
		cli.Lat = la
		cli.Lng = lo
		cli.Value = 10
		data = append(data, cli)
	}

	rand.Seed(time.Now().UnixNano())
	pts := algorithm.RandomPoints([2]malg.Point{
		malg.Point{41.542137, 2.426475},
		malg.Point{41.538419, 2.451129},
	}, 100)

	clusters := algorithm.KmeansMaxDist(pts, radius)
	//for _, c := range clusters {
	//fmt.Println(c.Centroid, "-->", c.Pts)
	//}

	c.Data["data"] = pts
	c.Data["clusters"] = clusters
	c.Data["cradius"] = radius
	c.TplName = "dashboard.tpl"
}
