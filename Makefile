.PHONY: all clean install uninstall

all: currency

currency:
	perl CurrencyGraphic.pm currency.pm
