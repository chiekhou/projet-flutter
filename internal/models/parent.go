package models

import "gorm.io/gorm"

type Parent struct {
	gorm.Model
	PointsAccumules int
	UserID  uint    `gorm:"uniqueIndex"`
	User    User    `gorm:"constraint:OnDelete:CASCADE;"`
	Enfants []Eleve `gorm:"foreignKey:ParentID"`
}
