package models

import "gorm.io/gorm"

type Eleve struct {
	gorm.Model
	UserID          uint `gorm:"uniqueIndex"`
	User            User `gorm:"constraint:OnDelete:CASCADE;"`
	ParentID        *uint
	Parent          Parent `gorm:"foreignKey:ParentID"`
	PointsAccumules int
}
