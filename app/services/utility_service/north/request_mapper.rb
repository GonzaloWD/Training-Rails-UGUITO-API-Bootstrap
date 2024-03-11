module UtilityService
  module North
    class RequestMapper < UtilityService::RequestMapper
      def retrieve_books(params)
        build_params_with_author(params)
      end

      def retrieve_notes(params)
        build_params_with_author(params)
      end

      private

      def build_params_with_author(params)
        {
          autor: params['author']
        }
      end

      def retrieve_notes(params)
        {
          autor: params['author']
        }
      end
    end
  end
end
