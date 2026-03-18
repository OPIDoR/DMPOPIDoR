import { createDirectus, graphql } from '@directus/sdk';

const createClient = (url) => {
  const client = createDirectus(url).with(graphql());
  return client;
};

const getHelp = async (url) => {
  const client = createClient(url);
  return client.query(`
    query {
      faq_categories(filter: { published: { _eq: true } }) {
        icon {
          id
          filename_download
        }
        translations {
          languages_code {
            code
          }
          title
        }
        questions(filter: { published: { _eq: true } }) {
          translations {
            languages_code {
              code
            }
            question
            answer
          }
        }
      }
    }
  `);
};

const getGlossary = async (url) => {
  const client = createClient(url);
  return client.query(`
    query {
      glossary(filter: { status: { _eq: "published" } }) {
        translations {
          languages_code {
            code
          }
          term
          description
        }
      }
    }
  `);
};

const getStaticPage = async (url, page) => {
  const client = createClient(url);
  return client.query(`
    query {
      static_pages(filter: { status: { _eq: "published" }, path: { _eq: "${page}" } }) {
        path,
        translations {
          languages_code {
            code
          }
          title,
          content
        }
      }
    }
  `);
};

export default {
  getHelp,
  getGlossary,
  getStaticPage,
};
