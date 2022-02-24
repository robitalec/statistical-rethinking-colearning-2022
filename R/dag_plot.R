#' DAG plot through dot graphviz
#' @author Alec L. Robitaille
#'
#' @param dag 
#' @param output_path without extension
#'
#' @return
#' @export
#'
#' @examples
dag_plot <- function(dag, output_path) {
  dag <- gsub('exposure', 'style=filled; color="#dfc9de"', dag)
  dag <- gsub('outcome', 'style=filled; color="#ffe0bd"', dag)
  dag <- gsub('dag', 'digraph', dag)
  dag <- gsub('}', 'rankdir=LR}', dag)

  dot_path <- paste0(output_path, '.dot')
  png_path <- paste0(output_path, '.png')
  writeLines(dag, dot_path)
  system(paste0('dot -Gdpi=300 -Tpng ', dot_path, ' > ', png_path)) 
  p <- png::readPNG(png_path)
  return(grid::grid.raster(p))
}
