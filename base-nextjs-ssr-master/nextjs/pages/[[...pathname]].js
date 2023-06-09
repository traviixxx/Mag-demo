import { useState, useEffect } from 'react';
import { EditablePage } from '@magnolia/react-editor';
import Navigation from '../templates/components/Navigation';
import Basic from '../templates/pages/Basic';
import Contact from '../templates/pages/Contact';
import Headline from '../templates/components/Headline';
import Image from '../templates/components/Image';
import Paragraph from '../templates/components/Paragraph';
import Expander from '../templates/components/Expander';
import List from '../templates/components/List';
import Item from '../templates/components/Item';
import { languages, getCurrentLanguage, setURLSearchParams } from '../utils';

const nodeName = '/nextjs-ssr-minimal';
const config = {
  componentMappings: {
    'nextjs-ssr-minimal-lm:pages/basic': Basic,
    'nextjs-ssr-minimal-lm:pages/contact': Contact,

    'spa-lm:components/headline': Headline,
    'spa-lm:components/image': Image,
    'spa-lm:components/paragraph': Paragraph,
    'spa-lm:components/expander': Expander,
    'spa-lm:components/list': List,
    'spa-lm:components/listItem': Item,
  },
};

// Use different defaultBaseUrl to point to public instances
const defaultBaseUrl = process.env.PUBLIC_MGNL_HOST;
const pagesApi = defaultBaseUrl + '/.rest/delivery/pages/v1';
const pagenavApi = defaultBaseUrl + '/.rest/delivery/pagenav/v1';

// More info about personalization of headless projects https://docs.magnolia-cms.com/product-docs/6.2/Developing/SPA-development-and-Magnolia/Personalization-of-headless-SPA-projects.html
// Fetch all variants inside Magnolia WYSIWYG in edit mode
function p13n(pagePath, isPagesAppEdit) {
  let newPagePath = pagePath;

  if (isPagesAppEdit) {
    newPagePath += newPagePath.indexOf('?') > -1 ? '&' : '?';
    newPagePath += 'variants=all';
  }

  return newPagePath;
}

export async function getServerSideProps(context) {
  const resolvedUrl = context.resolvedUrl;
  const currentLanguage = getCurrentLanguage(resolvedUrl);
  const isDefaultLanguage = currentLanguage === languages[0];
  const isPagesApp = context.query?.mgnlPreview || null;
  let props = {
    isPagesApp,
    isPagesAppEdit: isPagesApp === 'false',
    basename: isDefaultLanguage ? '' : '/' + currentLanguage,
    pagePath: nodeName + context.resolvedUrl.replace(new RegExp('.*' + nodeName), ''), // Find out page path to fetch from Magnolia
    baseUrl: process.env.PUBLIC_MGNL_HOST
  };

  global.mgnlInPageEditor = props.isPagesAppEdit;

  if (!isDefaultLanguage) {
    props.pagePath = props.pagePath.replace('/' + currentLanguage, '');
  }

  // Fetching page content
  const pagesRes = await fetch(
    p13n(setURLSearchParams(pagesApi + props.pagePath, 'lang=' + currentLanguage), props.isPagesAppEdit)
  );
  props.page = await pagesRes.json();

  // Fetching page navigation
  const pagenavRes = await fetch(setURLSearchParams(pagenavApi + nodeName, 'lang=' + currentLanguage));
  props.pagenav = await pagenavRes.json();

  return {
    props,
  };
}

export default function Pathname(props) {
  const [templateAnnotations, setTemplateAnnotations] = useState();
  const { page, pagenav, isPagesApp, isPagesAppEdit, basename, pagePath, baseUrl } = props;

  // Fetch template annotations only inside Magnolia WYSIWYG
  useEffect(() => {
    async function fetchTemplateAnnotations() {
      const templateAnnotationsApi = baseUrl + '/.rest/template-annotations/v1';
      const templateAnnotationsRes = await fetch(templateAnnotationsApi + pagePath);
      const templateAnnotationsJson = await templateAnnotationsRes.json();

      setTemplateAnnotations(templateAnnotationsJson);
    }

    if (isPagesApp) fetchTemplateAnnotations();
  }, [isPagesApp, pagePath, baseUrl]);

  // In Pages app wait for template annotations before rendering EditablePage
  const shouldRenderEditablePage = page && (isPagesApp ? templateAnnotations : true);

  return (
    <div className={isPagesAppEdit ? 'disable-a-pointer-events' : ''}>
      {pagenav && <Navigation content={pagenav} nodeName={nodeName} basename={basename} />}
      {shouldRenderEditablePage && (
        <EditablePage content={page} config={config} templateAnnotations={templateAnnotations} />
      )}
    </div>
  );
}
