module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            title: note['TituloNota'],
            type: note['ReseniaNota'].to_b ? 'review' : 'critique',
            created_at: note['FechaCreacionNota'],
            user: user_details(note),
            book: book_details(note)
          }
        end
      end

      def first_name(full_name)
        full_name.split.first
      end

      def last_name(full_name)
        full_name.split.second
      end

      def user_details(note)
        {
          email: note['EmailAutor'],
          first_name: first_name(note['NombreCompletoAutor']),
          last_name: last_name(note['NombreCompletoAutor'])
        }
      end

      def book_details(note)
        {
          title: note['TituloLibro'],
          author: note['NombreAutorLibro'],
          genre: note['GeneroLibro']
        }
      end
    end
  end
end
