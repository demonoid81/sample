package service_2

import (
	"github.com/rs/zerolog"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"reflect"
	"sample/internal/data/models/core"
	"sample/internal/utils"
)

var (
	cfg     = core.Config{}
	rootCmd = &cobra.Command{
		Use:   "oracle",
		Short: "Oracle is a very fast static site generator",
		Run: func(cmd *cobra.Command, args []string) {
			_ = cmd.Help()
		},
	}
	bootstrap = true
)

func Execute() {
	cobra.CheckErr(rootCmd.Execute())
}

var (
	commit  string
	buildAt string
	version string
)

func init() {
	v1 := viper.New()
	v1.SetConfigType("yaml")
	v1.AddConfigPath(".")
	err := v1.ReadInConfig()
	if err != nil {
		panic(err)
	}

	if err := parseEnv(v1, &cfg, "", "_"); err != nil {
		panic(err)
	}

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	zerolog.SetGlobalLevel(utils.StringToLevel(cfg.LogLevel))
}

func parseEnv(v1 *viper.Viper, i interface{}, parent, delim string) error {
	r := reflect.TypeOf(i)

	if r.Kind() == reflect.Ptr {
		r = r.Elem()
	}

	for i := 0; i < r.NumField(); i++ {

		f := r.Field(i)
		env := f.Tag.Get("mapstructure")
		if env == "" {
			continue
		}
		if parent != "" {
			env = parent + delim + env
		}

		if f.Type.Kind() == reflect.Struct {
			t := reflect.New(f.Type).Elem().Interface()
			parseEnv(v1, t, env, delim)
			continue
		}

		if e := v1.BindEnv(env); e != nil {
			return e
		}
	}
	return v1.Unmarshal(i)
}
