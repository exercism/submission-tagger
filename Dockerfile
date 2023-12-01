FROM public.ecr.aws/lambda/ruby:2.7 AS build

RUN yum install gcc make -y

ENV GEM_HOME=${LAMBDA_TASK_ROOT}
WORKDIR ${LAMBDA_TASK_ROOT}
COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM public.ecr.aws/lambda/ruby:2.7 AS runtime

ENV GEM_HOME=${LAMBDA_TASK_ROOT}
WORKDIR ${LAMBDA_TASK_ROOT}

COPY --from=build ${LAMBDA_TASK_ROOT}/ ${LAMBDA_TASK_ROOT}/
COPY lib/ lib/

CMD [ "lib/submission_tagger.SubmissionTagger.process" ]
