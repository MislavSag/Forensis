

Sys.getenv("TOKEN")
Sys.getenv("IME")


# DATA API ----------------------------------------------------------------
# Search ZK
zk_l = lapply(terms, function(x) {
  p = GET("http://dac.hr/api/v1/query",
          query = list(
            q = x,
            history = "false",
            part = 2, # 1 SVe , 2 B
            limit = 100,
            skip = 0
          ),
          add_headers(`X-DataApi-Key` = Sys.getenv("TOKEN")))
  res = content(p)
  res = rbindlist(res$hits)
  as.data.table(cbind.data.frame(term = x, res))
})
lapply(zk_l, function(x) nrow(x))
lapply(zk_l, function(x) nrow(x[type == "zk"]))
zkdt = rbindlist(zk_l)
zkdt_unique = unique(zkdt[, .SD, .SDcols = -"term"])
