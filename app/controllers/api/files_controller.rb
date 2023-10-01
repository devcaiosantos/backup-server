class Api::FilesController < ActionController::Base
    def list
        # Verifique se o parâmetro 'backup_name' foi enviado na solicitação.
        if params[:backup_name].present?
            backup_folder = Rails.root.join('data', params[:backup_name])
        
            # Verifique se a pasta de backup existe.
            if File.exist?(backup_folder)
                # Obtenha uma lista de todos os arquivos na pasta de backup.
                files = Dir.entries(backup_folder).select { |entry| File.file?(File.join(backup_folder, entry)) && entry != '.' && entry != '..' }
        
                # Obtenha informações sobre cada arquivo.
                file_info = []
                files.each do |file|
                    file_path = File.join(backup_folder, file)
                    file_info << {
                        name: file,
                        size: File.size(file_path),
                        created_at: File.ctime(file_path),
                        updated_at: File.mtime(file_path)
                    }
                end
                @folder = params[:backup_name]
                @files = file_info
            else
                render json: { error: 'A pasta de backup não existe.' }, status: :unprocessable_entity
            end
        else
            render json: { error: 'O nome do backup não foi fornecido.' }, status: :unprocessable_entity
        end
    end

    def delete
      backup_name = params[:backup_name]
      file_name = params[:file_name]
  
      if backup_name.present? && file_name.present?
        backup_folder = Rails.root.join('data', backup_name)
        file_path = File.join(backup_folder, file_name)
  
        if File.exist?(file_path)
          File.delete(file_path)
          redirect_to action: 'list', backup_name: backup_name
        else
          render json: { message: "Arquivo #{file_name} não encontrado no backup #{backup_name}." }, status: :not_found
        end
      else
        render json: { message: 'Parâmetros "backup_name" e "file_name" são obrigatórios.' }, status: :unprocessable_entity
      end
    end

    def download
        backup_name = params[:backup_name]
        file_name = params[:file_name]
    
        if backup_name.present? && file_name.present?
          backup_folder = Rails.root.join('data', backup_name)
          file_path = File.join(backup_folder, file_name)
    
          if File.exist?(file_path)
            # Configure o cabeçalho de resposta Content-Disposition para forçar o download.
            send_file file_path, disposition: 'attachment'
          else
            render json: { error: "O arquivo #{file_name} não foi encontrado no backup #{backup_name}." }, status: :not_found
          end
        else
          render json: { error: 'Os parâmetros "backup_name" e "file_name" são obrigatórios.' }, status: :unprocessable_entity
        end
    end
end