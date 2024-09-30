package models

import "gorm.io/gorm"

type Parent struct {
	gorm.Model
	ID      uint    `gorm:"primary_key" json:"id"`
	UserID  uint    `gorm:"uniqueIndex"`
	User    User    `gorm:"constraint:OnDelete:CASCADE;"`
	Enfants []Eleve `gorm:"foreignKey:ParentID"`
}
