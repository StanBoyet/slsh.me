module PlatformIconsHelper
  def browser_icon(name, css_class: "w-3.5 h-3.5")
    key = name.to_s.downcase.strip
    svg = BROWSER_ICONS.find { |pattern, _| key.include?(pattern) }&.last || BROWSER_ICONS["_fallback"]
    tag.svg(svg.html_safe, xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "currentColor", class: css_class)
  end

  def os_icon(name, css_class: "w-3.5 h-3.5")
    key = name.to_s.downcase.strip
    svg = OS_ICONS.find { |pattern, _| key.include?(pattern) }&.last || OS_ICONS["_fallback"]
    tag.svg(svg.html_safe, xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 24 24", fill: "currentColor", class: css_class)
  end

  # Simple monochrome SVG path data for each browser
  BROWSER_ICONS = {
    "chrome" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="12" r="4" fill="none" stroke="currentColor" stroke-width="1.5"/><line x1="12" y1="8" x2="12" y2="2" stroke="currentColor" stroke-width="1.5"/><line x1="8.5" y1="14" x2="3.1" y2="17" stroke="currentColor" stroke-width="1.5"/><line x1="15.5" y1="14" x2="20.9" y2="17" stroke="currentColor" stroke-width="1.5"/>',
    "safari" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><polygon points="8,16 10.5,10.5 16,8 13.5,13.5" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><circle cx="12" cy="12" r="0.5" fill="currentColor"/>',
    "firefox" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M17.5 8.5a6.5 6.5 0 00-8 1c-.5.6-.8 1.5-.5 2.5.5 1.5 2 2 3 1.5s1-2 2.5-2.5c1-.3 2 .2 2.5 1s0 2-1 2.5-2.5.5-4 0a5 5 0 01-3-3" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>',
    "edge" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M7 14c0-3.5 2.5-6 6-6s5 2 5 4.5c0 1.5-1 2.5-2.5 2.5H9" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><circle cx="8" cy="16" r="1.5" fill="none" stroke="currentColor" stroke-width="1.2"/>',
    "opera" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><ellipse cx="12" cy="12" rx="4" ry="7" fill="none" stroke="currentColor" stroke-width="1.5"/>',
    "samsung" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M8 12c0-2 1.5-4 4-4s4 2 4 4-1.5 4-4 4" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>',
    "brave" => '<path d="M12 2L4 6v5c0 5 3.5 9.7 8 11 4.5-1.3 8-6 8-11V6l-8-4z" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><path d="M9 10l3 2 3-2M9 14l3 2 3-2" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>',
    "arc" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M8 8a6 6 0 018 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><circle cx="12" cy="14" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>',
    "_fallback" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="12" r="4" fill="none" stroke="currentColor" stroke-width="1.5"/>'
  }.freeze

  OS_ICONS = {
    "mac" => '<path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83" fill="none" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="none" stroke="currentColor" stroke-width="1.3"/>',
    "ios" => '<path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83" fill="none" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/><path d="M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" fill="none" stroke="currentColor" stroke-width="1.3"/>',
    "windows" => '<path d="M3 5.5l7.5-1v7H3zm0 13l7.5 1v-7H3zm8.5 1.2L21 21V12.5h-9.5zm0-15.4V12.5H21V3l-9.5 1.3z" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linejoin="round"/>',
    "android" => '<path d="M5 16V9c0-3.87 3.13-7 7-7s7 3.13 7 7v7" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><rect x="4" y="10" width="16" height="10" rx="2" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="9" cy="7" r="0.75" fill="currentColor"/><circle cx="15" cy="7" r="0.75" fill="currentColor"/><line x1="8" y1="2" x2="6" y2="0.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/><line x1="16" y1="2" x2="18" y2="0.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/>',
    "linux" => '<path d="M12 2C9.5 2 8 4.5 8 7v3c-1.5 1-3 2.5-3 4.5 0 1 .5 2 1.5 2.5.5 1.5 2 3 5.5 3s5-1.5 5.5-3c1-.5 1.5-1.5 1.5-2.5 0-2-1.5-3.5-3-4.5V7c0-2.5-1.5-5-4-5z" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/><circle cx="10" cy="8" r="0.75" fill="currentColor"/><circle cx="14" cy="8" r="0.75" fill="currentColor"/><path d="M10 11.5c0 .5 1 1.5 2 1.5s2-1 2-1.5" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round"/>',
    "chrome os" => '<circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="12" r="4" fill="none" stroke="currentColor" stroke-width="1.5"/><line x1="12" y1="8" x2="12" y2="2" stroke="currentColor" stroke-width="1.5"/>',
    "_fallback" => '<rect x="4" y="2" width="16" height="14" rx="2" fill="none" stroke="currentColor" stroke-width="1.5"/><line x1="8" y1="20" x2="16" y2="20" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><line x1="12" y1="16" x2="12" y2="20" stroke="currentColor" stroke-width="1.5"/>'
  }.freeze
end
