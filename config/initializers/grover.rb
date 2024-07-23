Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '5px',
      bottom: '10cm'
    },
    user_agent: 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0',
    viewport: {
      width: 1920,
      height: 1080
    },
    prefer_css_page_size: true,
    emulate_media: 'screen',
    bypass_csp: true,
    timezone: 'Europe/Paris',
    cache: false,
    timeout: 2000,
    request_timeout: 1000,
    convert_timeout: 2000,
    launch_args: ['--font-render-hinting=medium'],
    wait_until: 'domcontentloaded'
  }
end