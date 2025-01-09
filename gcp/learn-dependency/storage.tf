resource "google_storage_bucket" "example_bucket" {
    name = "kia-learning-terraform-gcp-bucket"
    location = "US"
    website {
      main_page_suffix = "index.html"
      not_found_page = "404.html"
    }
}
