const http = require('http')
const port = 3000

const routes = {
  'GET': {
    '/bla': (req, res) => {
      const body = JSON.stringify({ results: [1, 2, 3] })

      res.writeHead(200, {'Content-Type': 'application/json'})
      res.end(body)
    }
  },
  'POST': {
    '/bla': (req, res) => {
      const data = req.body
      const body = JSON.stringify({ name: data.name })

      res.writeHead(200, {'Content-Type': 'application/json'})
      res.end(body)
    }
  }
}

const serverError = (code, res) => {
  res.writeHead(code, {'Content-Type': 'text/plain'})
  res.end(http.STATUS_CODES[code])

}

const callRoute = (route, req, res) => {
  const response = route(req, res)
  res.writeHead(200, {'Content-Type': 'application/json'})
  res.end(JSON.stringify(response))
}

const handleRequest = (req, res) => {
  const route = (routes[req.method] || {})[req.url]

  if (!route) {
    return serverError(404, res)
  }

  if (!req.headers['content-type'] || req.headers['content-type'] == 'application/json') {
    let body = []

    req.on('error', (err) => {
      console.error(err)
    }).on('data', (chunk) => {
      body.push(chunk)
    }).on('end', () => {
      body = Buffer.concat(body).toString()
      if (body.length == 0) {
        return callRoute(route, req, res)
      }

      try {
        req.body = JSON.parse(body)
        callRoute(route, req, res)
      } catch (e) {
        return serverError(400, res)
      }
    })
  } else {
    callRoute(route, req, res)
  }
}

const server = http.createServer(handleRequest)

server.listen(port, () => {
  console.log('Server listening on: http://localhost:%s', port)
})
