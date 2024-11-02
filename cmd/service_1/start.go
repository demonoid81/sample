package service_1

import (
	"github.com/rs/zerolog/log"
	"github.com/spf13/cobra"
	"sample/internal/services/service_1"
)

func init() {
	rootCmd.AddCommand(tryStart)
}

var tryStart = &cobra.Command{
	Use:   "start",
	Short: "Try and possibly fail at something",
	RunE: func(cmd *cobra.Command, args []string) error {
		l := log.With().Str("Service", "service_2").Logger()

		service_1.NewService(commit, buildAt, version, &l)

		return nil
	},
}
