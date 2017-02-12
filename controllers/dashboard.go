package controllers

import (
	"encoding/csv"
	"io"
	"log"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/astaxie/beego"
	"github.com/novikk/mpaths-alg/algorithm"
	malg "github.com/novikk/mpaths-alg/models"
)

type DashboardController struct {
	beego.Controller
}

var pts malg.Points
var latestModification time.Time

func init() {
	latestModification = time.Now()
	rand.Seed(time.Now().UnixNano())
	f, _ := os.Open("mataro.in")

	r := csv.NewReader(f)

	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}

		lat, _ := strconv.ParseFloat(record[0], 64)
		lng, _ := strconv.ParseFloat(strings.TrimSpace(record[1]), 64)

		pts = append(pts, malg.Point{lat, lng})
	}
}

func (c *DashboardController) Get() {
	radius := 200.0

	// pts := algorithm.RandomPoints([2]malg.Point{
	// 	malg.Point{41.542137, 2.426475},
	// 	malg.Point{41.538419, 2.451129},
	// }, 100)

	//clusters := algorithm.KmeansMaxDist(pts, radius)
	//for _, c := range clusters {
	//fmt.Println(c.Centroid, "-->", c.Pts)
	//}
	//var routes models.Routes

	routes, clusters := algorithm.GetRoutesAndClusters(pts)

	c.Data["data"] = pts
	c.Data["clients"] = pts
	c.Data["routes"] = routes
	c.Data["clusters"] = clusters
	c.Data["cradius"] = radius
	c.TplName = "dashboard.tpl"
}

func (c *DashboardController) AddPoint() {
	lat, _ := c.GetFloat("lat")
	lng, _ := c.GetFloat("lng")

	pts = append(pts, malg.Point{lat, lng})
	latestModification = time.Now()
}

func (c *DashboardController) GetLatestModification() {
	c.Data["json"] = latestModification
	c.ServeJSON()
}
