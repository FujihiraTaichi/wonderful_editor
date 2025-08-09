module Api
  module V1
    module Auth
      class RegistrationsController < DeviseTokenAuth::RegistrationsController
        # まずは継承のみ（必要になったら override）
      end
    end
  end
end
