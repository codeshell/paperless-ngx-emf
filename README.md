# Paperless-ngx + Email Meta Fields (paperless-ngx-emf)

[![Create and publish a Docker image](https://github.com/codeshell/paperless-ngx-emf/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/codeshell/paperless-ngx-emf/actions/workflows/build-and-push.yml)

## What is this about?

The Dockerfile in this repository merges a modification (see [Source Data](#source-data)) onto the official Paperless-ngx Docker image.

> It changes the email import function so that for every mail or attachment processed, the most important meta data are saved to custom fields.

- E-Mail Subject
- E-Mail Sender (from)
- E-Mail Receiver (to)
- Message date

This ensures your imports do not loose their context.

## How to use

### Option 1: Build your own image

Run the Dockerfile yourself to build the modified image. Works well with automation tools like Ansible or management interfaces like Komodo.

You can pass any version number you want to use as variable to overwrite the default from the Dockerfile:

```sh
PATCH_IMAGETAG=3.3.3
```

### Option 2: Use the pre-build packages

Instead of building yourself you can also use the packages in this repository. These are the ones I use myself.

I suggest you use version tags instead of `latest` if you pull and update your images automatically.

For example:

```diff
---    image: ghcr.io/paperless-ngx/paperless-ngx:3.3
+++    image: ghcr.io/codeshell/paperless-ngx-emf:3.3
```

or:

```diff
---    image: ghcr.io/paperless-ngx/paperless-ngx:latest
+++    image: ghcr.io/codeshell/paperless-ngx-emf:latest
```

## Source data

[Robin Moser](https://github.com/robin-moser) created a [fork](https://github.com/robin-moser/paperless-ngx/tree/feature-mail-metadata-custom-fields) in 2025 adding a crucial feature to paperless-ngx:

> [!IMPORTANT]
> ##### [Feature Request] Email metadata to Custom Fields #10551
> 
> https://github.com/paperless-ngx/paperless-ngx/discussions/10551

## Problem

When **importing emails** with Paperless-ngx, **metadata are dropped along the way**. Notably, the message date.

As a result, when importing "attachments-only with keeping file names" from an inbox with existing mail, all those documents are consumed **defaulting to the current date** as creation date.

In addition, the **documents loose their context** like sender, receiver and subject.

Imagine importing 1000 attachments.

There might be a contract document in a mail from 2020 together with an amendment and terms and conditions and a pricelist.
There might be another mail with an invoice from 2025 again with some separate attachments.

While some documents like invoices often contain enough context to carry themselves (dates, addresses, subject, references, contract id, legal contact, ...) and Paperless-ngx is doing an amazing job at extracting those, complementary documents often lack any such information.
That is often intended and even necessary as for reused documents like terms and conditions.

Now, imagine again having those 1000 documents in Paperless-ngx consumed without context.

A good portion of it will be unusable because you have tell where or to whom to what they belong.
Let's call them orphans.
Even some of the documents that carry their own context within their content will be incomplete.
Like loosing your sidecar files to the contract.

> [!NOTE]
> ##### Opinion
> In the current state, I consider this modification not a "Feature Request" but a "Bug".
> 
> If the mail import would at least default the "document creation date" to the message date, instead of the current date, there would at least be some basic context so that any call for additional meta files might indeed qualify as "Feature Request".
