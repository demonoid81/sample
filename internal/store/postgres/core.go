package mysql

import "github.com/rs/zerolog/log"

// setConnection устанавливает подключение к БД
func setConnection(debug bool) (err error) {
	const fn = "store.postgresql.setConnection"
	log.Info().Msgf("%s: %v", fn, "ok")
	return
}
