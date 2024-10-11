# Suppress R CMD check note
# Namespace in Imports field not imported from: PKG
#   All declared Imports should be used.
ignore_unused_imports <- function() {
  sigshared::example_signature
  sigsim::sig_simulate_catalogues_from_signatures
  sigstash::sig_available
  sigstats::sig_cosine_similarity
  sigstory::sig_story
  sigvis::sig_visualise
}
