# frozen_string_literal: true

class GraphiqlController < ActionController::Base
  def show
    render html: <<~HTML.html_safe, layout: false # rubocop:disable Rails/OutputSafety
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>GraphiQL — Arkheion</title>
          <style>
            body { margin: 0; height: 100vh; overflow: hidden; }
            #graphiql { height: 100vh; }
          </style>
          <link rel="stylesheet" href="https://unpkg.com/graphiql@3/graphiql.min.css" />
        </head>
        <body>
          <div id="graphiql">Loading…</div>

          <script src="https://unpkg.com/react@18/umd/react.production.min.js" crossorigin></script>
          <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js" crossorigin></script>
          <script src="https://unpkg.com/graphiql@3/graphiql.min.js" crossorigin></script>

          <script>
            const fetcher = GraphiQL.createFetcher({
              url: '/graphql',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.cookie.match(/csrf-token=([^;]+)/)?.[1] ?? ''
              }
            });

            const root = ReactDOM.createRoot(document.getElementById('graphiql'));
            root.render(React.createElement(GraphiQL, { fetcher }));
          </script>
        </body>
      </html>
    HTML
  end
end
