package service_2

import (
	"github.com/rs/zerolog"
)

type service struct {
	commit  string
	buildAt string
	version string

	log   *zerolog.Logger
	store Store
}

type Store interface {
	// Работа с БД
}

func NewService(commit, buildAt, version string, log *zerolog.Logger) *service {

	return &service{
		commit:  commit,
		buildAt: buildAt,
		version: version,
		log:     log,
	}
}

func (s *service) SetStore(store Store) {
	s.store = store
}
