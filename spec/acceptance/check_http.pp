check_http {'https://www.google.com':
  expected_statuses  => [200],
  body_matcher => /Google/,
  request_timeout => 30,
  retries => 3,
  backoff => 1,
  exponential_backoff_base => 2,
  max_backoff => 40,
  timeout  => 60,
}
