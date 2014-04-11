SOURCES = $(wildcard src/**/*.lua src/*.lua)
TARGET = rssc-sendmail

all: $(TARGET)

$(TARGET): $(SOURCES)
	./merge.lua src main.lua > $(TARGET)
	chmod +x $(TARGET)

clean:
	rm -f $(TARGET)

install:
	cp $(TARGET) /usr/bin
