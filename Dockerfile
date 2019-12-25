FROM golang:1.13.4 as thumbtest_builder

RUN apt-get update && apt-get install -y gnupg2
RUN echo "deb http://pkg.mxe.cc/repos/apt xenial main" > /etc/apt/sources.list.d/mxeapt.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 86B72ED9
RUN apt-get update && apt-get install -y \
	mxe-i686-w64-mingw32.static-gcc \
	mxe-i686-w64-mingw32.static-libidn \
	mxe-i686-w64-mingw32.static-ffmpeg \
	mxe-i686-w64-mingw32.static-graphicsmagick

ENV PATH="/usr/lib/mxe/usr/bin:${PATH}"
ENV GO111MODULE=on
RUN mkdir /thumbtest
WORKDIR /thumbtest
COPY go.mod go.sum ./
RUN go mod download
COPY . .


ENV WIN_ARCH=386
ENV MXE_ROOT=/usr/lib/mxe/usr
ENV MXE_TARGET=i686-w64-mingw32.static

# HACK to cross-compile thumbnailer package for windows
# because of error cannot use "_Ctype_ulong(img.size) (type _Ctype_ulong) as type _Ctype_uint in field value"
# this line cover_art.go:26 in thumbnailer is not compatible with linux and windows
# we have to explicitly change it before compilation
RUN sed -i s/C.ulong/C.uint/g /go/pkg/mod/github.com/bakape/thumbnailer/v2@v2.5.4/cover_art.go

RUN CGO_ENABLED=1 GOOS=windows GOARCH=$WIN_ARCH \
	CC=$MXE_ROOT/bin/$MXE_TARGET-gcc \
	CXX=$MXE_ROOT/bin/$MXE_TARGET-g++ \
	PKG_CONFIG=$MXE_ROOT/bin/$MXE_TARGET-pkg-config \
	PKG_CONFIG_LIBDIR=$MXE_ROOT/$MXE_TARGET/lib/pkgconfig \
	PKG_CONFIG_PATH=$MXE_ROOT/$MXE_TARGET/lib/pkgconfig \
 	go build  -a -o /go/bin/thumbtest.exe --ldflags '-extldflags "-static"' /thumbtest

FROM alpine:3.5
COPY --from=thumbtest_builder /go/bin/thumbtest.exe /bin
