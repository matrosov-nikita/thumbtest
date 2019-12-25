package main

import (
	"flag"
	"log"
	"os"

	"github.com/bakape/thumbnailer/v2"
)

func main() {
	imgPath := flag.String("image", "", "test image")
	flag.Parse()

	f, err := os.Open(*imgPath)
	if err != nil {
		log.Fatal(err)
	}

	defer f.Close()

	ctx, err := thumbnailer.NewFFContext(f)
	if err != nil {
		log.Fatal(err)
	}

	defer ctx.Close()

	dims, err := ctx.Dims()
	if err != nil {
		log.Fatal(err)
	}

	_, err = ctx.Thumbnail(dims)
	if err != nil {
		log.Fatal(err)
	}
}
