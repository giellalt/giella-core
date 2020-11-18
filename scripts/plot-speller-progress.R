# plot-speller-progress.R
# Plot progression of spelling correction results
# (c) 2020 Divvun and Giellatekno, GNU GPLv3

svg(file="speller-report.svg")
t <- read.delim("speller-report.tsv")
totals <- t$worse + t$no.suggs + t$wrong.suggs
top1percent <- t$top1 / totals
top5percent <- t$top5 / totals
worsepercent <- t$worse / totals
wrongpercent <- t$wrong.suggs / totals
nopercent <- t$no.suggs / totals
colours = c("darkgreen", "green", "lightgreen", "orange", "red")
labels =  c("1st -", "<=5th -", "Any -", "Only wrong -", "No -" )
type =    c("-",           "-",     "-",            "-", "-")
p <- plot(top1percent, type="o", xlab="Date", ylab="Accuracy %",
          main="South-Sámi spellchecker quality progress chart",
          col=colours[1], ylim=c(0.0, 1.0))
lines(top5percent, type="o", col="green")
lines(worsepercent, type="o", col="lightgreen")
lines(wrongpercent, type="o", col="orange")
lines(nopercent, type="o", col="red")
legend(1, 1,  labels, title="suggestions", col=colours, pch=type)
dev.off()
