dbcritic: $(shell find -name '*.idr')
	idris --total -o dbcritic Main.idr
