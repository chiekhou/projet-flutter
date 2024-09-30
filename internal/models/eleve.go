package models

import "gorm.io/gorm"

type Eleve struct {
	gorm.Model
	ID              uint `gorm:"primary_key" json:"id"`
	UserID          uint `gorm:"uniqueIndex"`
	User            User `gorm:"constraint:OnDelete:CASCADE;"`
	ParentID        *uint
	Parent          Parent `gorm:"foreignKey:ParentID"`
	PointsAccumules int
}
