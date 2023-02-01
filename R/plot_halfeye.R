#' Eye plots (violin + interval) using ggdist
#' @return
#' @author Alec L. Robitaille
#' @export
plot_halfeye <- function(DT, x, facet = NULL) {
  
  if (missing(DT)) stop('missing DT')
  if (missing(x)) stop('missing x')

  g <- ggplot(DT, aes_string(x)) +
    theme_bw(base_size = 16) +
    stat_halfeye() +
    geom_vline(xintercept = 0, color = 'grey', alpha = 0.2, size = 0.8)
  
  if (!is.null(facet)) {
    g <- g + facet_wrap(facet, scales = 'free_x')
  }
  
  g
}
