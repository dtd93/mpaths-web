package models

type Route []Point
type Point struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lon"`
}

type Routes []Route
