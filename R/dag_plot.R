#' DAG plot
#' @author Alec L. Robitaille
#'
#' @param dag 
#'
#' @return
#' @export
#'
#' @examples
dag_plot <- function(dag) {
	stat <- node_status(dag, FALSE)
	stat$data$status[is.na(stat$data$status)] <- 'intermediate'
	ggplot(stat, aes(x = x, y = y, xend = xend, yend = yend)) +
		geom_dag_point(aes(color = status), alpha = 0.5, size = 15) +
		geom_dag_edges() +
		labs(color = '') +
		geom_dag_text(color = 'black') +
		scale_color_manual(values = list('exposure' = '#35608DFF',
																		 'outcome' = '#22A884FF',
																		 'intermediate' = 'grey50')) +
		theme_void()
}
