
###########
# Imports #
###########

library(plyr)
library(plotrix)
library(ggplot2)
library(reshape2)


#######################
# Auxiliary functions #
#######################


# geometric mean
gm_mean = function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

# return the string of a rounded number
printnum = function(x, k=2){
  format(round(x, k), nsmall=k)
}

MYBLUE  = rgb(0/255, 0/255, 255/255, .8)
MYRED   = rgb(255/255, 0/255, 0/255, .8)
MYGREEN = rgb(0/255, 128/255, 0/255, .8)


###############
# Import data #
###############


# read CSV results
results_beemorig_read = read.csv("results-beem-orig.csv")
results_beemgen_read  = read.csv("results-beem-gen.csv")
results_mcc_read      = read.csv("results-mcc2015.csv")

# read SCC sizes statistics (computed using https://github.com/vbloemen/ltsmin -b sccsize)
results_beemorig_scc      = read.csv("scc/beem-orig-noltl-scc.csv")
results_beemorig_scc_ba   = read.csv("scc/beem-orig-spotba-ltl-scc.csv")
results_beemorig_scc_tgba = read.csv("scc/beem-orig-tgba-ltl-scc.csv")
results_beemgen_scc       = read.csv("scc/beem-gen-noltl-scc.csv")
results_beemgen_scc_ba    = read.csv("scc/beem-gen-spotba-ltl-scc.csv")
results_beemgen_scc_tgba  = read.csv("scc/beem-gen-tgba-ltl-scc.csv")
results_mcc_scc           = read.csv("scc/mcc2015-noltl-scc.csv")
results_mcc_scc_ba        = read.csv("scc/mcc2015-spotba-ltl-scc.csv")
results_mcc_scc_tgba      = read.csv("scc/mcc2015-tgba-ltl-scc.csv")

# read LTL counterexample lengths for UFSCC
results_beemorig_ce       = read.csv("results-ce/results-beem-orig.csv")
results_beemgen_ce        = read.csv("results-ce/results-beem-gen.csv")
results_mcc_ce            = read.csv("results-ce/results-mcc2015.csv")


###############
# Filter data #
###############


# Only take all CORRECT results (NB: unknown if fully correct for MCC and SPIN)
results_beemorig_correct = subset(results_beemorig_read, ifelse(grepl("_T_",model), ltl == -1, ltl != -1))
results_beemgen_correct  = subset(results_beemgen_read,  ifelse(grepl("_T_",model), ltl == -1, ltl != -1))
results_mcc_correct      = subset(results_mcc_read,      ifelse(grepl("_T_",model), ltl == -1, ltl != -1))

# Also for the correct UFSCC counterexample lengths..
results_beemorig_correct_ce = subset(results_beemorig_ce, ifelse(grepl("_T_",model), ltl == -1, ltl != -1))
results_beemgen_correct_ce  = subset(results_beemgen_ce,  ifelse(grepl("_T_",model), ltl == -1, ltl != -1))
results_mcc_correct_ce      = subset(results_mcc_ce,      ifelse(grepl("_T_",model), ltl == -1, ltl != -1))

# Take the mean times per model,alg,buchi,workers combination (NB: these functions will take some time..)
results_beemorig_mean = ddply(results_beemorig_correct, .(model,alg,workers,buchi), summarize, time = gm_mean(time), ltl = gm_mean(ltl), ustates = gm_mean(ustates), utrans = gm_mean(utrans), tstates = gm_mean(tstates), ttrans = gm_mean(ttrans), selfloop = gm_mean(selfloop), claimdead = gm_mean(claimdead), claimfound = gm_mean(claimfound), claimsuccess = gm_mean(claimsuccess), cumstack = gm_mean(cumstack), buchisize = gm_mean(buchisize))
results_beemgen_mean  = ddply(results_beemgen_correct,  .(model,alg,workers,buchi), summarize, time = gm_mean(time), ltl = gm_mean(ltl), ustates = gm_mean(ustates), utrans = gm_mean(utrans), tstates = gm_mean(tstates), ttrans = gm_mean(ttrans), selfloop = gm_mean(selfloop), claimdead = gm_mean(claimdead), claimfound = gm_mean(claimfound), claimsuccess = gm_mean(claimsuccess), cumstack = gm_mean(cumstack), buchisize = gm_mean(buchisize))
results_mcc_mean      = ddply(results_mcc_correct,      .(model,alg,workers,buchi), summarize, time = gm_mean(time), ltl = gm_mean(ltl), ustates = gm_mean(ustates), utrans = gm_mean(utrans), tstates = gm_mean(tstates), ttrans = gm_mean(ttrans), selfloop = gm_mean(selfloop), claimdead = gm_mean(claimdead), claimfound = gm_mean(claimfound), claimsuccess = gm_mean(claimsuccess), cumstack = gm_mean(cumstack), buchisize = gm_mean(buchisize))

# Also for the correct UFSCC counterexample lenghts..
results_beemorig_mean_ce = ddply(results_beemorig_correct_ce, .(model,alg,workers,buchi), summarize, ltl = gm_mean(ltl))
results_beemgen_mean_ce  = ddply(results_beemgen_correct_ce,  .(model,alg,workers,buchi), summarize, ltl = gm_mean(ltl))
results_mcc_mean_ce      = ddply(results_mcc_correct_ce,      .(model,alg,workers,buchi), summarize, ltl = gm_mean(ltl))

# Which data points are obtained from which data set?
results_beemorig_mean$data  = "beem-orig"
results_beemgen_mean$data   = "beem-gen"
results_mcc_mean$data       = "mcc2015"

# only add SCC info if we have it, otherwise add empty rows
results_beemorig = rbind(merge(results_beemorig_mean, results_beemorig_scc_ba, by=c("buchi","model"), all.x=TRUE), merge(results_beemorig_mean, results_beemorig_scc_tgba, by=c("buchi","model"), all.x=TRUE))
results_beemgen  = rbind(merge(results_beemgen_mean,  results_beemgen_scc_ba,  by=c("buchi","model"), all.x=TRUE), merge(results_beemgen_mean,  results_beemgen_scc_tgba,  by=c("buchi","model"), all.x=TRUE))
results_mcc      = rbind(merge(results_mcc_mean,      results_mcc_scc_ba,      by=c("buchi","model"), all.x=TRUE), merge(results_mcc_mean,      results_mcc_scc_tgba,      by=c("buchi","model"), all.x=TRUE))

# combine all data
results_combined_noscc = rbind(rbind(results_beemorig_mean, results_beemgen_mean), results_mcc_mean)
results_combined       = rbind(rbind(results_beemorig, results_beemgen), results_mcc)


##################
# Plot functions #
##################


# Scatterplot speedup function (without colors)
f_scatter_speedup = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model) & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = MYBLUE,
       pch = ifelse(grepl("_F_",comb_model$model), 3, 1))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd=2)
  
  if (ce_type == "both") {
    legend("topleft", pch=c(3,1), col=c(MYRED, MYBLUE), c("Accepting cycle", "No accepting cycle"), bty="0", bg="white")
  }
  dev.off()
}

# Show by color where the models were obtained from
f_scatter_speedup_origin = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  if (ce_type == "ce") {
    data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y)
  } else if (ce_type == "noce") {
    data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001 & ustates > 10^6)
  }
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model) & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  a = subset(comb_model, comb_model$data.x == "beem-gen")
  aa = a$time.x / a$time.y
  b = subset(comb_model, comb_model$data.x == "beem-orig")
  bb = b$time.x / b$time.y
  c = subset(comb_model, comb_model$data.x == "mcc2015")
  cc = c$time.x / c$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$data.x == "beem-gen",MYGREEN, ifelse(comb_model$data.x == "beem-orig", MYRED, MYBLUE)),
       pch = ifelse(comb_model$data.x == "beem-gen", 3, ifelse(comb_model$data.x == "beem-orig", 1, 2)))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft", pch=c(3,1,2), col=c(MYGREEN, MYRED,MYBLUE), c("BEEM-gen", "BEEM-orig", "MCC"), bty="0", bg="white", title="Model origins")
  dev.off()
}

# Show differences in the number of transitions with colors
f_scatter_speedup_trans  = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model) & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  # print(sprintf("Geometric average relative speedup: %f", gm_mean(y)))
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$utrans.y > 100000000, MYGREEN, 
                    ifelse(comb_model$utrans.y > 10000000, MYRED, MYBLUE)),
       pch = ifelse(comb_model$utrans.y > 100000000, 3, 
                    ifelse(comb_model$utrans.y > 10000000, 1,2)))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd=2)
  legend("topleft", pch=c(3,1,2), col=c(MYGREEN, MYRED,MYBLUE), c("1E8 .. 1E9", "1E7 .. 1E8", "1E6 .. 1E7"), 
         bty="0", bg="white", title="|Transitions|")
  dev.off()
}

# Show differences in the fanout with colors
f_scatter_speedup_fanout  = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model) & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  # print(sprintf("Geometric average relative speedup: %f", gm_mean(y)))
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$utrans.y / comb_model$ustates.y > 8, "black", 
                    ifelse(comb_model$utrans.y / comb_model$ustates.y > 6, MYGREEN,
                           ifelse(comb_model$utrans.y / comb_model$ustates.y > 4, MYBLUE, 
                                  ifelse(comb_model$utrans.y / comb_model$ustates.y > 3, "purple", 
                                         ifelse(comb_model$utrans.y / comb_model$ustates.y > 2, MYRED, "orange" ))))),
       pch = ifelse(comb_model$utrans.y / comb_model$ustates.y > 8, 1, 
                    ifelse(comb_model$utrans.y / comb_model$ustates.y > 6, 2, 
                           ifelse(comb_model$utrans.y / comb_model$ustates.y > 4, 3, 
                                  ifelse(comb_model$utrans.y / comb_model$ustates.y > 3, 4, 
                                         ifelse(comb_model$utrans.y / comb_model$ustates.y > 2, 5, 6 ))))))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft", pch=c(1,2,3,4,5,6), col=c("black", MYGREEN, MYBLUE,"purple", MYRED, "orange"), c("8 ..", "6 .. 8", "4 .. 6", "3 .. 4", "2 .. 3", "0 .. 2"), 
         bty="0", bg="white", title="Fanout")
  dev.off()
}

# Show SCC statistics with colors [We only want data where ustates and utrans are the same (allstates=ustates, alltrans=utrans)]
f_scatter_speedup_scc = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001) # & alltrans == utrans & allstates == ustates)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model))# & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$largest_scc.y / comb_model$ustates.y > 0.5, MYGREEN, 
             ifelse(comb_model$largest_scc.y / comb_model$ustates.y > 0.01, MYRED, MYBLUE)),
       pch = ifelse(comb_model$largest_scc.y / comb_model$ustates.y  > 0.5, 3, 
             ifelse(comb_model$largest_scc.y / comb_model$ustates.y  > 0.01, 1, 2)))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  #abline(h=64, col = "black", lwd = 2)
  legend("topleft",title=" |Largest SCC| / |states| ", pch=c(3,1,2), col=c(MYGREEN,MYRED,MYBLUE), 
         c("50% - 100%", 
           "  1% - 50%",
           "  0% - 1%"), bty="0", bg="white")
  dev.off()
}

# Show SCC statistics with colors (using SCC info from the x-axis)
f_scatter_speedup_scc_2 = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001) # & alltrans == utrans & allstates == ustates)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model))# & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$largest_scc.x / comb_model$ustates.x > 0.5, MYGREEN, 
                    ifelse(comb_model$largest_scc.x / comb_model$ustates.x > 0.01, MYRED, MYBLUE)),
       pch = ifelse(comb_model$largest_scc.x / comb_model$ustates.x  > 0.5, 3, 
                    ifelse(comb_model$largest_scc.x / comb_model$ustates.x  > 0.01, 1, 2)))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft",title=" |Largest SCC| / |states| ", pch=c(3,1,2), col=c(MYGREEN,MYRED,MYBLUE), 
         c("50% - 100%", 
           "  1% - 50%",
           "  0% - 1%"), bty="0", bg="white")
  dev.off()
}

# Speedup comparison for UFSCC BA and TGBA (showing persistence)
f_scatter_speedup_tgba = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model)) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  print(head(comb_model))
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$persistence.x == "yes", MYBLUE, MYRED),
       pch = ifelse(comb_model$persistence.x == "yes", 3, 1))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft",title="LTL classification", pch=c(3,1), col=c(MYBLUE,MYRED), 
         c("persistence", 
           "no persistence"), bty="0", bg="white")
  dev.off()
}

# Speedup comparison for UFSCC BA and TGBA (showing cross product sizes of exploration)
f_scatter_speedup_tgba_2 = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model)) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$utrans.x > comb_model$utrans.y, MYGREEN, 
                    ifelse(comb_model$utrans.x == comb_model$utrans.y, MYRED, MYBLUE)),
       pch = ifelse(comb_model$utrans.x > comb_model$utrans.y, 3, 
                    ifelse(comb_model$utrans.x == comb_model$utrans.y, 1, 2)))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft",title="|Transitions|", pch=c(3,1,2), col=c(MYGREEN,MYRED,MYBLUE), 
         c("|BA| < |TGBA|", "|BA| = |TGBA|", "|BA| > |TGBA|"), bty="0", bg="white")
  dev.off()
}

# Speedup comparison for counterexample lengths
f_scatter_speedup_ltl = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model)) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       ylim=c(miny,maxy),
       xlim=c(mintime,maxtime),
       log="xy", 
       col = ifelse(comb_model$ltl.x > comb_model$ltl.y, MYGREEN, MYRED),
       pch = ifelse(comb_model$ltl.x > comb_model$ltl.y, 3, 1))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft",title="|Counterexample|", pch=c(3,1), col=c(MYGREEN,MYRED), 
         c("UFSCC < CNDFS", "UFSCC > CNDFS"), bty="0", bg="white")
  dev.off()
}

# Show how the counter example length compares with colors
f_scatter_speedup_ce = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, alg_y, buchi_y, workers_y, mintime, maxtime, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime & ltl > 0)
  data_y     = subset(data, alg == alg_y & buchi == buchi_y & workers == workers_y & time > 0.001 & ltl > 0)
  
  # combine the data
  comb_model_all = merge(data_x, data_y, by="model", all = FALSE)
  comb_model = comb_model_all
  if (ce_type == "ce") {
    comb_model = subset(comb_model_all,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(comb_model_all,  grepl("_T_",model) & comb_model$ustates.y <= comb_model$tstates.x) # we assume that UFSCC (data_y) is correct
  }
  x = comb_model$time.x
  y = comb_model$time.x / comb_model$time.y
  
  options(scipen=5)
  pdf(sprintf("plots/%s.pdf", pdf_name), width=6, height=5)
  
  plot(x,y, 
       xlab=sprintf("%s", x_name),
       ylab=sprintf("%s", y_name),
       log="xy", 
       col = ifelse(comb_model$ltl.x > comb_model$ltl.y,MYGREEN, MYRED),
       pch = ifelse(comb_model$ltl.x > comb_model$ltl.y, 3, 2))
  
  grid(nx=NULL, ny=NULL, col= "black", lty="dotted", equilogs=FALSE)
  abline(h=1, col = "black", lwd = 2)
  legend("topleft", pch=c(3,2), col=c(MYGREEN, MYRED), c("|CE| UFSCC shorter", "|CE| UFSCC longer"), bty="0", bg="white", title="CE length comparison")
  dev.off()
}

# Successor distribution function
f_work = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, mintime=0.001, maxtime=600, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime & utrans > 0)
  comb_model = data_x
  if (ce_type == "ce") {
    comb_model = subset(data_x,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(data_x,  grepl("_T_",model)) # we assume that UFSCC (data_y) is correct
  }
  
  x = comb_model$ustates
  y = comb_model$time
  
  large_scc = subset(comb_model, largest_scc > -1 & largest_scc / ustates > 0.5 )
  med_scc   = subset(comb_model, largest_scc > -1 & largest_scc / ustates <= 0.5 & largest_scc / ustates > 0.01)
  small_scc = subset(comb_model, largest_scc > -1 & largest_scc / ustates <= 0.01)
  
  large_tot = gm_mean(large_scc$claimsuccess) + gm_mean(large_scc$claimfound) + gm_mean(large_scc$claimdead)
  large = c(gm_mean(large_scc$claimsuccess) / large_tot, gm_mean(large_scc$claimfound) / large_tot, gm_mean(large_scc$claimdead) / large_tot)
  
  med_tot = gm_mean(med_scc$claimsuccess) + gm_mean(med_scc$claimfound) + gm_mean(med_scc$claimdead)
  med = c(gm_mean(med_scc$claimsuccess) / med_tot, gm_mean(med_scc$claimfound) / med_tot, gm_mean(med_scc$claimdead) / med_tot)
  
  small_tot = gm_mean(small_scc$claimsuccess) + gm_mean(small_scc$claimfound) + gm_mean(small_scc$claimdead)
  small = c(gm_mean(small_scc$claimsuccess) / small_tot, gm_mean(small_scc$claimfound) / small_tot, gm_mean(small_scc$claimdead) / small_tot)
  
  frame = as.matrix(data.frame(small,med,large))
  
  print(frame)
  
  colnames(frame) = c("small", "medium", "large")
  rownames(frame) = c("new", "visited", "dead")
  
  pdf(sprintf("plots/%s.pdf", pdf_name), width=3.4, height=3)
  
  barplot(frame, col=c("green","blue","red"), angle = 45*1:3, density = 25, yaxt="n", ylab="cumulative percentage", xlab="SCC sizes", 
          legend = rownames(frame), args.legend = list(x = "topleft", inset=c(-0.25,-0.5), horiz=TRUE))
  points=c(0.0,0.2,0.4,0.6,0.8,1.0)
  axis(2, at=points, lab=paste0(points * 100, "%"), las=TRUE)
  
  dev.off()
}

# Successor distribution function (using transitions)
f_work_trans = function(data, ce_type, pdf_name, title, x_name, y_name, alg_x, buchi_x, workers_x, mintime=0.001, maxtime=600, miny=0.1, maxy=100) {
  
  # filter out the required data for configurations x and y
  data_x     = subset(data, alg == alg_x & buchi == buchi_x & workers == workers_x & time > mintime & time < maxtime & utrans > 0)
  comb_model = data_x
  if (ce_type == "ce") {
    comb_model = subset(data_x,  grepl("_F_",model))
  } else if (ce_type == "noce") {
    comb_model = subset(data_x,  grepl("_T_",model)) # we assume that UFSCC (data_y) is correct
  }
  
  x = comb_model$ustates
  y = comb_model$time
  
  large_scc = subset(comb_model, utrans  < 1E7)
  med_scc   = subset(comb_model, utrans >= 1E7 & utrans < 1E8)
  small_scc = subset(comb_model, utrans >= 1E8)
  
  large_tot = gm_mean(large_scc$claimsuccess) + gm_mean(large_scc$claimfound) + gm_mean(large_scc$claimdead)
  large = c(gm_mean(large_scc$claimsuccess) / large_tot, gm_mean(large_scc$claimfound) / large_tot, gm_mean(large_scc$claimdead) / large_tot)
  
  med_tot = gm_mean(med_scc$claimsuccess) + gm_mean(med_scc$claimfound) + gm_mean(med_scc$claimdead)
  med = c(gm_mean(med_scc$claimsuccess) / med_tot, gm_mean(med_scc$claimfound) / med_tot, gm_mean(med_scc$claimdead) / med_tot)
  
  small_tot = gm_mean(small_scc$claimsuccess) + gm_mean(small_scc$claimfound) + gm_mean(small_scc$claimdead)
  small = c(gm_mean(small_scc$claimsuccess) / small_tot, gm_mean(small_scc$claimfound) / small_tot, gm_mean(small_scc$claimdead) / small_tot)
  
  frame = as.matrix(data.frame(small,med,large))
  colnames(frame) = c("small", "medium", "large")
  rownames(frame) = c("new", "visited", "dead")
  
  pdf(sprintf("plots/%s.pdf", pdf_name), width=3.4, height=3)
  
  barplot(frame, col=c("green","blue","red"), angle = 45*1:3, density = 25, yaxt="n", ylab="cumulative percentage", xlab="Transitions", 
          legend = rownames(frame), args.legend = list(x = "topleft", inset=c(-0.25,-0.5), horiz=TRUE))
  points=c(0.0,0.2,0.4,0.6,0.8,1.0)
  axis(2, at=points, lab=paste0(points * 100, "%"), las=TRUE)
  
  dev.off()
}


##########
# Tables #
##########


f_table_T = function(results) {
  ufscc_T   = subset(results, alg == "ufscc"   & workers == 64 & buchi == "spotba")
  ndfs_T    = subset(results, alg == "ndfs"    & workers == 1  & buchi == "spotba")
  cndfs_T   = subset(results, alg == "cndfs"   & workers == 64 & buchi == "spotba")
  renault_T = subset(results, alg == "renault" & workers == 64 & buchi == "spotba")
  tgba_T    = subset(results, alg == "ufscc"   & workers == 64 & buchi == "tgba"  )
  bfs_T     = subset(results, alg == "bfs"     & workers == 64 & buchi == "spotba")
  
  sprintf("{\tt ~%s (%s)~} & {\tt ~%s (%s)~} & {\tt ~%s (%s)~} & {\tt ~%s (%s)~} & {\tt ~%s~} \\", 
          printnum(gm_mean(ndfs_T$time)),    printnum(gm_mean(ndfs_T$time)    / gm_mean(ufscc_T$time)),
          printnum(gm_mean(cndfs_T$time)),   printnum(gm_mean(cndfs_T$time)   / gm_mean(ufscc_T$time)),
          printnum(gm_mean(renault_T$time)), printnum(gm_mean(renault_T$time) / gm_mean(ufscc_T$time)),
          printnum(gm_mean(tgba_T$time)),    printnum(gm_mean(tgba_T$time)    / gm_mean(ufscc_T$time)),
          printnum(gm_mean(ufscc_T$time)))
}

# Models without counterexamples

trans_s_results_T = subset(results_combined_noscc,  alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & utrans < 10^7)
trans_m_results_T = subset(results_combined_noscc,  alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & utrans >= 10^7 & utrans < 10^8)
trans_l_results_T = subset(results_combined_noscc,  alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & utrans >= 10^8)
scc_s_results_T   = subset(results_combined,        alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & largest_scc / ustates < 0.01)
scc_m_results_T   = subset(results_combined,        alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & largest_scc / ustates >= 0.01 & largest_scc / ustates < 0.5)
scc_l_results_T   = subset(results_combined,        alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & largest_scc / ustates >= 0.5)
total_results_T   = subset(results_combined_noscc,  alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model))

print("{\bf NDFS}~ & ~{\bf CNDFS}~ & ~{\bf Renault}~ & ~{\bf UFSCC-TGBA}~ & ~{\bf UFSCC-BA}~ \\")
f_table_T(results_combined_noscc[results_combined_noscc$model %in% trans_s_results_T$model,])
f_table_T(results_combined_noscc[results_combined_noscc$model %in% trans_m_results_T$model,])
f_table_T(results_combined_noscc[results_combined_noscc$model %in% trans_l_results_T$model,])
f_table_T(results_combined[results_combined$model %in% scc_s_results_T$model,])
f_table_T(results_combined[results_combined$model %in% scc_m_results_T$model,])
f_table_T(results_combined[results_combined$model %in% scc_l_results_T$model,])
f_table_T(results_combined_noscc[results_combined_noscc$model %in% total_results_T$model,])

# Models with counterexamples

total_results_F    = subset(results_combined_noscc, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_F_",model))

print("{\bf NDFS}~ & ~{\bf CNDFS}~ & ~{\bf Renault}~ & ~{\bf UFSCC-TGBA}~ & ~{\bf UFSCC-BA}~ \\")
f_table_T(results_combined_noscc[results_combined_noscc$model %in% total_results_F$model,])


#########
# Plots #
#########


f_scatter_speedup_origin(data=results_combined_noscc, ce_type="noce", pdf_name = "f-ndfs-noce", title="",
                              x_name="time for NDFS-1 (in sec)", y_name = "time NDFS-1 / time UFSCC-64",
                              alg_x = "ndfs", buchi_x = "spotba", workers_x = 1,
                              alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 3, maxtime=500, miny=0.75, maxy=100) 

f_scatter_speedup_origin(data=results_combined, ce_type="ce", pdf_name = "f-ndfs-ce", title="",
                              x_name="time for NDFS-1 (in sec)", y_name = "time NDFS-1 / time UFSCC-64",
                              alg_x = "ndfs", buchi_x = "spotba", workers_x = 1,
                              alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 0.01, maxtime=599.999, miny=0.2, maxy=500) 


f_scatter_speedup_trans(data=results_combined_noscc, ce_type="noce", pdf_name = "f-cndfs-noce", title="",
                        x_name="time for CNDFS-64 (in sec)", y_name = "time CNDFS-64 / time UFSCC-64",
                        alg_x = "cndfs", buchi_x = "spotba", workers_x = 64,
                        alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 0.3, maxtime=100, miny=0.3, maxy=10) 

f_scatter_speedup(data=results_combined_noscc, ce_type="ce", pdf_name = "f-cndfs-ce", title="",
                      x_name="time for CNDFS-64 (in sec)", y_name = "time CNDFS-64 / time UFSCC-64",
                      alg_x = "cndfs", buchi_x = "spotba", workers_x = 64,
                      alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 0.01, maxtime=10, miny=0.1, maxy=50) 

f_scatter_speedup_scc(data=results_combined, ce_type="noce", pdf_name = "f-renault-noce", title="",
                        x_name="time for Renault-64 (in sec)", y_name = "time Renault-64 / time UFSCC-64",
                        alg_x = "renault", buchi_x = "spotba", workers_x = 64,
                        alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 0.3, maxtime=500, miny=0.4, maxy=100) 

f_scatter_speedup(data=results_combined_noscc, ce_type="ce", pdf_name = "f-renault-ce", title="",
                  x_name="time for Renault-64 (in sec)", y_name = "time Renault-64 / time UFSCC-64",
                  alg_x = "renault", buchi_x = "spotba", workers_x = 64,
                  alg_y = "ufscc", buchi_y = "spotba", workers_y = 64, mintime = 0.01, maxtime=500, miny=0.09, maxy=500) 

f_scatter_speedup_tgba_2(data=results_combined_noscc, ce_type="noce", pdf_name = "f-tgba-noce", title="",
                      x_name="time for UFSCC-TGBA-64 (in sec)", y_name = "time UFSCC-TGBA-64 / time UFSCC-BA-64",
                      alg_x = "ufscc", buchi_x = "tgba", workers_x = 64,
                      alg_y = "ufscc", buchi_y = "spotba",   workers_y = 64, mintime = 0.25, maxtime=50, miny=0.4, maxy=5) 

f_scatter_speedup_tgba_2(data=results_combined_noscc, ce_type="ce", pdf_name = "f-tgba-ce", title="",
                       x_name="time for UFSCC-TGBA-64 (in sec)", y_name = "time UFSCC-TGBA-64 / time UFSCC-BA-64",
                       alg_x = "ufscc", buchi_x = "tgba", workers_x = 64,
                       alg_y = "ufscc", buchi_y = "spotba",   workers_y = 64, mintime = 0.010, maxtime=10, miny=0.1, maxy=10) 



######################
# Additional results #
######################

f_work(data=results_combined, ce_type="noce", pdf_name = "f-work", title="",
       x_name="TEMP", y_name = "TEMP",
       alg_x = "ufscc", buchi_x = "spotba", workers_x = 64) 

# re-exploration

re_noce        = subset(results_combined, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model))
re_noce_trans_m = subset(results_combined, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & utrans >= 10^7 & utrans < 10^8)
re_noce_trans_l = subset(results_combined, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & utrans >= 10^8)
re_ce           = subset(results_combined, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_F_",model))

sprintf("ratio re-exploration without CE:           %s", (gm_mean(re_noce$ttrans) / gm_mean(re_noce$utrans)))
sprintf("ratio re-exploration without CE (trans M): %s", (gm_mean(re_noce_trans_m$ttrans) / gm_mean(re_noce_trans_m$utrans)))
sprintf("ratio re-exploration without CE (trans L): %s", (gm_mean(re_noce_trans_l$ttrans) / gm_mean(re_noce_trans_l$utrans)))
sprintf("ratio re-exploration with CE:              %s", (gm_mean(re_ce$ttrans) / gm_mean(re_ce$utrans)))


uf_t = subset(results_combined, alg == "ufscc" & workers == 64 & buchi == "spotba" &  grepl("_T_",model) & 
                largest_scc / allstates > 0.01  & 
                largest_scc / allstates < 0.5)
print (gm_mean(uf_t$ustates))
print (gm_mean(uf_t$tstates) / gm_mean(uf_t$ustates))

















