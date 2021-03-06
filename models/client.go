package models

import "github.com/jinzhu/gorm"

type Client struct {
	gorm.Model `json:"-"`
	Lat        float64 `json:"lat"`
	Lng        float64 `json:"lon"`
	Value      float64 `json:"val"`
}

type ClientsData []Client
