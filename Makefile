.PHONY: uniform derangements compare clean
uniform:
	Rscript R/main.R --mode uniform --reps 20000 --animate TRUE --frames 240 --outdir results
derangements:
	Rscript R/main.R --mode derangements --n 200 --reps 20000 --animate TRUE --frames 240 --outdir results
compare:
	Rscript R/main.R --mode compare --n 200 --reps 20000 --outdir results
clean:
	rm -rf results/*