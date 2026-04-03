export default function createHeaders(params = {}, csrf = false) {
  const opts = params || {};

  return {
    'Content-Type': 'application/json',
    'X-CSRF-Token': csrf ? document.querySelector('meta[name="csrf-token"]')?.content : undefined,
    ...opts,
  };
}
