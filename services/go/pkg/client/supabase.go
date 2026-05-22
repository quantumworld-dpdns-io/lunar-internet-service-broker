package client

import (
	"os"

	"github.com/supabase-community/supabase-go"
)

type SupabaseClient struct {
	client *supabase.Client
}

func NewSupabaseClient() (*SupabaseClient, error) {
	url := os.Getenv("SUPABASE_URL")
	key := os.Getenv("SUPABASE_SERVICE_KEY")
	if url == "" || key == "" {
		return nil, nil
	}
	client, err := supabase.NewClient(url, key, nil)
	if err != nil {
		return nil, err
	}
	return &SupabaseClient{client: client}, nil
}

func (s *SupabaseClient) GetClient() *supabase.Client {
	return s.client
}
