class Api::UploadsController < ApplicationController
    def upload
        # Verifique se o parâmetro 'backup_name' foi enviado na solicitação.
        if params[:backup_name].present?
          # Crie uma nova pasta dentro de 'data' com o nome do backup.
          backup_folder = Rails.root.join('data', params[:backup_name])
          FileUtils.mkdir_p(backup_folder)
    
          # Salve os arquivos enviados na pasta do backup.
          params[:files].each do |uploaded_file|
            file_path = File.join(backup_folder, uploaded_file.original_filename)
            File.open(file_path, 'wb') do |file|
              file.write(uploaded_file.read)
            end
          end
    
          render json: { message: 'Arquivos enviados com sucesso.' }
        else
          render json: { error: 'O nome do backup não foi fornecido.' }, status: :unprocessable_entity
        end
      end
end
