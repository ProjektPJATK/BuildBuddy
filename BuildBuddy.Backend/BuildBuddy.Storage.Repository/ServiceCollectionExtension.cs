using Amazon.S3;
using BuildBuddy.Storage.Abstraction;

namespace BuildBuddy.Storage.Repository;

public static class ServiceCollectionExtension
{
    public static IServiceCollection AddStorageServices(this IServiceCollection services, IConfiguration configuration)
    {
        var awsOptions = new AwsOptions();
        configuration.GetSection("AWS").Bind(awsOptions);

        Console.WriteLine($"AWS Access Key: {awsOptions.AccessKey}");
        Console.WriteLine($"AWS Region: {awsOptions.Region}");
        Console.WriteLine($"AWS Bucket Name: {awsOptions.BucketName}");
        
        var credentials = new Amazon.Runtime.BasicAWSCredentials(awsOptions.AccessKey, awsOptions.SecretKey);
        var s3Client = new AmazonS3Client(credentials, Amazon.RegionEndpoint.GetBySystemName(awsOptions.Region));
    
        services.AddSingleton<IAmazonS3>(s3Client);
        services.Configure<AwsOptions>(options => configuration.GetSection("AWS").Bind(options));
        services.AddScoped<IFileStorageRepository, FileStorageRepository>();
        return services;
    }
}