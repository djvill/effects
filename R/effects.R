# effect generic and methods; allEffects
# John Fox, Sanford Weisberg, and Jangman Hong
#  last modified 2012-12-08 by J. Fox
#  10/31/2012 modifed effect.lm to use z distn for ses with mer and nlme objects
# 12-21-2012 Allow for empty cells in factor interactions, S. Weisberg
# 7-15-2013:  S. Weisberg:  deleted 'default.levels' argument.  Changed and
#    generalized xlevels argument to include the function of default.levels.
# 2013-10-15: eliminated generic effect() and all its methods. J. Fox
# 2014-07-02: added vcov. argument to effect 
# 2014-12-10: Changed 'effect' back to a generic function.  S. Weisberg
# 2017-12-08: For compatibility with Effect.default, changed test for itercept i effect.default.  SW
# 2017-12-08: Removed unneeded allEffects.gls

effect <- function(term, mod, vcov.=vcov, ...){
  UseMethod("effect", mod)
}

effect.default <- function(term, mod, vcov.=vcov, ...){ 
  term <- gsub(" ", "", gsub("\\*", ":", term))
  terms <- term.names(mod)
  if ( terms[1] == "(Intercept)") terms <- terms[-1]
#  if (has.intercept(mod)) terms <- terms[-1]
  which.term <- which(term == terms)
  mod.aug<- list()
  if (length(which.term) == 0){
    message("NOTE: ", term, " does not appear in the model")
    mod.aug <- update(formula(mod), eval(parse(text=paste(". ~ . +", term))))
  }
  if (!is.high.order.term(term, mod, mod.aug))
    message("NOTE: ", term, " is not a high-order term in the model")
  predictors <- all.vars(parse(text=term)) 
  Effect(predictors, mod, vcov.=vcov., ...)
}


allEffects <- function(mod, ...) UseMethod("allEffects")

allEffects.default <- function(mod, ...){
  high.order.terms <- function(mod){
    names <- term.names(mod)
    if (has.intercept(mod)) names<-names[-1]
    rel <- lapply(names, descendants, mod=mod)
    (1:length(names))[sapply(rel, function(x) length(x)==0)]
  }
  names <- term.names(mod)
  if (has.intercept(mod)) names <- names[-1]
  if (length(names) == 0) stop("the model contains no terms (beyond a constant)")
  terms <- names[high.order.terms(mod)]
  result <- lapply(terms, effect, mod=mod, ...)
  names(result) <- terms
  class(result) <- 'efflist'
  result
}


