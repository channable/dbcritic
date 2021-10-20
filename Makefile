dbcritic-bin: $(shell find . -name '*.idr')
	idris --total -o dbcritic-bin Main.idr
